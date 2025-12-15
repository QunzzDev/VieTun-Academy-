<?php

namespace App\Models;

use App\Exceptions\AuditLogImmutableException;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AuditLog extends Model
{
    use HasUuids;

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'actor_id',
        'action',
        'resource_type',
        'resource_id',
        'data_json',
        'ip_address',
        'created_at',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'data_json' => 'array',
            'created_at' => 'datetime',
        ];
    }

    /**
     * Boot the model.
     */
    protected static function boot(): void
    {
        parent::boot();

        // Prevent updates to audit logs
        static::updating(function ($model) {
            throw new AuditLogImmutableException('Audit logs cannot be modified.');
        });

        // Prevent deletes of audit logs
        static::deleting(function ($model) {
            throw new AuditLogImmutableException('Audit logs cannot be deleted.');
        });
    }

    /**
     * Get the actor (user) who performed the action.
     */
    public function actor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'actor_id');
    }

    /**
     * Create a new audit log entry.
     */
    public static function log(
        string $action,
        string $resourceType,
        ?string $resourceId = null,
        ?array $data = null,
        ?string $actorId = null,
        ?string $ipAddress = null
    ): self {
        return self::create([
            'actor_id' => $actorId ?? auth()->id(),
            'action' => $action,
            'resource_type' => $resourceType,
            'resource_id' => $resourceId,
            'data_json' => $data,
            'ip_address' => $ipAddress ?? request()->ip(),
            'created_at' => now(),
        ]);
    }
}
